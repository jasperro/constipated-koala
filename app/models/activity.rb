class Activity < ActiveRecord::Base
  validates :name, presence: true

  validates :start_date, presence: true
  validate :end_is_possible, unless: "self.start_date.nil?"
  validate :unenroll_before_start, unless: "self.unenroll_date.nil?"
  validates :participant_limit, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    allow_nil: true
  }
#  validates :end_date
#  validates :description
#  validates :unenroll_date

  is_impressionable

  after_update :enroll_reservists, if: "participant_limit.changed?"

  has_attached_file :poster,
	:styles => { :thumb => ['180', :png], :medium => ['x1080', :png] },
	:processors => [:ghostscript, :thumbnail],
	:validate_media_type => false,
	:convert_options => { :all => '-colorspace CMYK -flatten -quality 100 -density 8' }

  validates_attachment_content_type :poster,
	 :content_type => 'application/pdf'

  has_one :group, :as => :organized_by

  has_many :participants, :dependent => :destroy
  has_many :members, :through => :participants

  before_validation do
    self.start_date = Date.today if self.start_date.blank?
    self.end_date = self.start_date if self.end_date.blank?
    self.unenroll_date = self.start_date - 2.days if self.unenroll_date.blank?
  end

  def name=(name)
    write_attribute(:name, name.strip)
  end

  def self.study_year( year )
    year = year.blank? ? Date.today.study_year : year.to_i
    where('start_date >= ? AND start_date < ?', Date.to_date( year ), Date.to_date( year +1 ))
  end

  def self.debtors
    # All participants who will receive payment reminders
    joins(:participants).where('
      activities.start_date <= ?
      AND
      participants.reservist IS FALSE
      AND
       (
        (activities.price IS NOT NULL
         AND
         participants.paid IS FALSE
         AND
         (participants.price IS NULL
          OR
          participants.price > 0)
        )
        OR
        (
         activities.price IS NULL
         AND
         participants.paid IS FALSE
         AND
         participants.price IS NOT NULL
        )
      )', Date.today).distinct
  end

  def group
    Group.find_by_id self.organized_by
  end

  def currency( member )
    participants.where(:member => member).first.price ||= self.price
  end

  def attendees
    participants.where(reservist: false)
  end

  def reservists
    participants.where(reservist: true)
  end

  def price
   return 0 if read_attribute(:price).nil?
   return read_attribute(:price)
  end

  def price=( price )
    price = price.to_s.gsub(',', '.').to_f
    write_attribute(:price, price)
    write_attribute(:price, NIL) if price == 0
  end

  def self.combine_dt(d, t)
    if t
      DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec)
    elsif d
      DateTime.new(d.year, d.month, d.day)
    else
      nil
    end
  end

  def start
    Activity.combine_dt(self.start_date, self.start_time)
  end

  def end
    Activity.combine_dt(self.end_date, self.end_time)
  end

  def end_is_possible
    errors.add(:end_date, :before_start_date) if end_date < start_date

    if end_time.present?
      if start_time.nil?
        errors.add(:start_time, :blank_and_end_time)
      elsif end_date == start_date && end_time < start_time
        errors.add(:end_time, :before_start_time)
      end
    end
  end

  def unenroll_before_start
    errors.add(:unenroll_date, :after_start_date) if start_date < unenroll_date
  end

  def enroll_reservists
    # Check whether it is possible to enroll some reservists
    # (participants.count < participant_limit), and then do that.
    #
    # Will not run if the unenroll_date has passed.
    #
    # This uses a magic instance variable to list any reservists that were
    # enrolled, ignore at your own risk.
    if self.is_enrollable? and self.unenroll_date >= DateTime.now
      if !self.participant_limit.nil? and
          self.attendees.count < self.participant_limit and
          self.reservists.count > 0
        spots = self.participant_limit - self.attendees.count
        luckypeople = self.reservists.first(spots)

        luckypeople.each do |peep|
          peep.update!(reservist: false)
          puts "#{peep.member.name} geontreservist"
        end

        @magic_enrolled_reservists = luckypeople
      end
    end
  end
end

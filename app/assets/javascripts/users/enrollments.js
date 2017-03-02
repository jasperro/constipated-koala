//= require sweetalert

//TODO jquery plugins for modal and activity
//TODO modal class
//TODO poster nav button hide/show to modol class

var token, modal, activity_container;

function batch_edit_properties(obj, edit_function) {
  Object.keys(obj).forEach(function (key) {
    obj[key] = edit_function(key, obj[key], obj);
  });

  return obj;
}

function confirm_enroll(activity) {
  var button_colour = "#23AE89"
  if (activity.fullness_display.text().trim() == Activity.full_string)
  {
    button_colour = "#ffb61c";
  }
  swal({
      title: "Je wordt ingeschreven voor deze activiteit. Weet je het zeker?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: button_colour,
      confirmButtonText: "Jep!",
      closeOnConfirm: false
    },
    // on confirm
    function () {
      if (activity.has_un_enroll_date_passed())
        confirm_un_enroll_date_passed(activity);
      else {
        swal.close();
        activity.enroll();
      }
    }
  );
}

function confirm_un_enroll_date_passed(activity) {
  var button_colour = "#DD6B55"
  if (activity.fullness_display.text().trim() == Activity.full_string)
  {
    button_colour = "#ffc64d";
  }

  swal({
      title: "De uitschrijfdeadline voor deze activiteit is verstreken. Je inschrijving kan dus niet ongedaan gemaakt worden. Weet je heel zeker dat je je wilt inschrijven?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: button_colour,
      confirmButtonText: "Jep!"
    }
    // anonymous function, because this is set to the sweetalert
    , function () {
      activity.enroll();
    }
  );
}

function confirm_un_enroll(activity) {
  if (activity.has_un_enroll_date_passed()) {
    swal('Uitschrijven mislukt!', 'De uitschrijfdeadline is al verstreken.', 'error');
    return;
  }
  var button_colour = "#DD6B55"
  if (activity.fullness_display.text().trim() == Activity.full_string)
  {
    button_colour = "#ffb61c";
  }

  swal({
      title: "Je schrijft je uit voor deze activiteit. Weet je het zeker?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: button_colour,
      confirmButtonText: "Jep!"
    }
    // anonymous function, because this is set to the sweetalert
    , function () {
      activity.un_enroll();
    }
  );
}

function confirm_update(activity) {
  var button_colour = "#5bc0de"
  swal({
      title: "Weet je zeker dat je deze informatie wilt bewerken?",
      type: "info",
      showCancelButton: true,
      confirmButtonColor: button_colour,
      confirmButtonText: "Jep!"
    }
    // anonymous function, because this is set to the sweetalert
    , function () {
      activity.edit_enroll();
    }
  );
}

/**
 * Loads the previous activity to the modal
 */
function prev_poster() {
  modal.activity_data.current.prev_activity.load_data_to_modal();
}


/**
 * Loads the next activity to the modal
 */
function next_poster() {
  modal.activity_data.current.next_activity.load_data_to_modal();
}

function initialize_enrollment() {
  activity_container = $('#activity-container');

  $('#enrollments').find('button.enrollment').on('click', function () {
    var activity = new Activity($(this).closest('.panel-activity'));
    if (activity.is_enrollable())
      confirm_enroll(activity);
    else
      confirm_un_enroll(activity);
  });
  $('#enrollments').find('button.update_enrollment').on('click', function(){
    var activity = new Activity($(this).closest('.panel-activity'));
    confirm_update(activity);
  });
}

function initialize_modal() {
  modal = $('#poster-modal');

  modal.activity_data = {
    img: modal.find('img')
    , title: modal.find('.activity-title')
    , more_info_link: modal.find('.more-info')
  };

  //Add event handler to poster to show the modal
  $(".show-poster-modal").on("click", function () {
    var activity = new Activity($(this).closest('.panel-activity'));
    activity.load_data_to_modal();

    modal.modal('show');
  });

//Add event handler to go to the previous activity in the modal
  $("#prev-poster").on("click", prev_poster);

//Add event handler to go to the next activity in the modal
  $("#next-poster").on("click", next_poster);
}

/**
 * Register all click handlers for enrollments
 */
$(document).on('ready page:load', function () {
  token = encodeURIComponent($(this).find('.page').attr('data-authenticity-token'));

  initialize_enrollment();
  initialize_modal();
});

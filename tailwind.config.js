module.exports = {
  darkMode: "media",
  // jit mode, this is still in preview but speeds up build
  // not compatible with semantic versioning yet
  mode: "jit",
  content: ["app/**/*.html.haml", "app/javascript/**/*.js"],
  theme: {
    extend: {
      colors: {
        board: "#fe7215",
      },
    },
    screens: {
      'sm': '640px',
      'md': '768px',
      'lg': '1024px',
      'xl': '1280px',
      '2xl': '1536px',
      '2xl-max': { 'max': '1535px' },
      'xl-max': { 'max': '1279px' },
      'lg-max': { 'max': '1023px' },
      'md-max': { 'max': '767px' },
      'sm-max': { 'max': '639px' },
    },
  },
  variants: {
    display: ["dark"],
  },
  plugins: [],
};

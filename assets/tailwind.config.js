const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        sky: colors.sky,
        cyan: colors.cyan
      }
    },
  },
  plugins: [require('@tailwindcss/forms')],
}

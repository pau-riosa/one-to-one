module.exports = {
  mode: "jit",
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
        blue: {
          900: "#1D3557",
        },
        yellow: {
          900: "#F2CC8F",
        },
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};

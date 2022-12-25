module.exports = {
  important: true,
  mode: "jit",
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
        "black-rgba": "rgba(0, 0, 0, 0.4)",
        blue: {
          900: "#1D3557",
          800: "#A8AFB9",
          700: "#E8EBF0",
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

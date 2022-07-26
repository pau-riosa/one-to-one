module.exports = {
  mode: "jit",
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
        blue: "#1D3557",
        yellow: "#F2CC8F",
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require("daisyui")],
};

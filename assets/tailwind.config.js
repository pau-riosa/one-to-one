module.exports = {
  mode: "jit",
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
        blue: {
          100: "#1D3557",
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
  plugins: [require("daisyui")],
};

# Running Locally

### macOS with Intel Processor
```
brew install srtp clang-format ffmpeg
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CFLAGS="-I/usr/local/opt/openssl@1.1/include/"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include/"
export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
```
### macOS with M1 processor
```
brew install srtp clang-format ffmpeg
export C_INCLUDE_PATH=/opt/homebrew/Cellar/libnice/0.1.18/include:/opt/homebrew/Cellar/opus/1.3.1/include:/opt/homebrew/Cellar/openssl@1.1/1.1.1l_1/include
export LIBRARY_PATH=/opt/homebrew/Cellar/opus/1.3.1/lib
export PKG_CONFIG_PATH=/opt/homebrew/Cellar/openssl@1.1/1.1.1l_1/lib/pkgconfig/
```
### Ubuntu
```
sudo apt-get install libsrtp2-dev libavcodec-dev libavformat-dev libavutil-dev
```
### Compilation Troubleshooting

If you encounter
```
** (Mix) Could not compile dependency :fast_tls, "/Users/meline-woolbird/.asdf/installs/elixir/1.13/.mix/rebar3 bare compile --paths /Users/meline-woolbird/projects/todo/_build/test/lib/*/ebin" command failed. Errors may have been logged above. You can recompile this dependency with "mix deps.compile fast_tls", update it with "mix deps.update fast_tls" or clean it with "mix deps.clean fast_tls"
```

run the following

1. mix deps.clean fast_tls
2. mix deps.get fast_tls
3. env LDFLAGS="-L$(brew --prefix openssl@1.1)/lib" CFLAGS="-I$(brew --prefix openssl@1.1)/include" mix compile

### Launching the Application
```
mix deps.get
npm i --prefix=assets
```
### Reference 

[Please see membrane_videoroom](https://github.com/membraneframework/membrane_videoroom)

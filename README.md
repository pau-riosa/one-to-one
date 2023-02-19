# Todo Changelogs

### From Glenn

✅ Don't ask for the email any more in the room link, Or maybe you can clarify why the email is being asked?
✅ Is there a way to switch cameras?
✅ Start `Free Button` from the bottom does not work.
✅  Dropdown for time should start at 8AM instead of 12AM
[ ] Needs to connect to my Calendar (GCal, maybe outlook and iCal as well) like Calendly so it doesn't suggest blocked off times
[ ] If it can also check the calendar of my invitee (assuming she is also using one-to-one) that would be doubley awesome!

### From Pau
✅ Removed already selected time in time-input. 
[ ] Send email to owner
[ ] Create a timer on video-conference based from user-duration.
[ ] Cron Job for deleting pass meetings since we have limited storage.
[ ] Sync with Google Calendar
[ ] Add Review After meeting 
[ ] Unit testing
[ ] Testing with Video Conference

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

# Compilation Troubleshooting

If you encounter
```
** (Mix) Could not compile dependency :fast_tls, "/Users/meline-woolbird/.asdf/installs/elixir/1.13/.mix/rebar3 bare compile --paths /Users/meline-woolbird/projects/todo/_build/test/lib/*/ebin" command failed. Errors may have been logged above. You can recompile this dependency with "mix deps.compile fast_tls", update it with "mix deps.update fast_tls" or clean it with "mix deps.clean fast_tls"
```
run the following

1. mix deps.clean fast_tls
2. mix deps.get fast_tls
3. env LDFLAGS="-L$(brew --prefix openssl@1.1)/lib" CFLAGS="-I$(brew --prefix openssl@1.1)/include" mix compile

# Launching the Application
```
mix deps.get
npm i --prefix=assets
```
# Reference 
[Please see membrane_videoroom](https://github.com/membraneframework/membrane_videoroom)

# Fly Commands

> flyctl checks list -a <app-name> 

shows health checks for the given app

> flyctl deploy

deploys an app

> flyctl secrets set SECRET_NAME=SECRET_VALUE

sets secret in your app


        <%= if @is_label do %>
          <label class="text-sm text-blue-900 font-normal"><%= @label %></label>
        <% end %>
        <div class="flex flex-row justify-between border border-gray-300 my-1 items-center rounded-md bg-white px-3 py-3">
          <%= select @form, @field, @times, selected: @default_next_day_time, class: "appearance-none w-full text-blue-900 font-md focus:outline-none focus:ring-blue focus:border-blue focus:z-10 sm:text-sm" %>
          <i><%= Heroicons.icon("clock", type: "solid", class: "h-5 w-5 fill-blue-900") %></i>
        </div>
        <%= error_tag @form, @field %>

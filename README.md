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

### Launching the Application
```
mix deps.get
npm i --prefix=assets
```
# Fly Commands

> flyctl checks list -a <app-name> 

shows health checks for the given app

> flyctl deploy

deploys an app

> flyctl secrets set SECRET_NAME=SECRET_VALUE

sets secret in your app

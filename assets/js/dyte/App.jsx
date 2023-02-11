import React from "react";
import { DyteMeeting } from 'dyte-client';

function App() {
  const uiConfigOptions = {
    colors: {
      primary:         '#1D3557',
      secondary:       '#1D3557',
      textPrimary:     '#FFFFFF',
      videoBackground: '#FFFFFF'
    }}

  const root = document.querySelector("#root")
  const orgId = root.dataset.orgId 
  const authToken = root.dataset.authToken 
  const roomName = root.dataset.roomName 

  return (
    <div className="App">
      <DyteMeeting
        onInit={(meeting) => {
          {/* meeting.updateUIConfig(uiConfigOptions); */}
          meeting.on(meeting.Events.disconnect, () => {
            // go to dashboard 
            window.location = "/"
          })
        }}
        clientId={orgId}
        meetingConfig={{
          roomName: roomName,
          authToken: authToken,
        }}
        uiConfig={uiConfigOptions}
      />
    </div>
  );
}

export default App;

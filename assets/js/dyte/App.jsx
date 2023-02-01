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
        clientId={`orgId || clientId`}
        meetingConfig={{
          roomName: `roomName`,
          authToken: `authToken`,
        }}
        uiConfig={uiConfigOptions}
      />
    </div>
  );
}

export default App;

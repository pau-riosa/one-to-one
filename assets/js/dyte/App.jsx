import React, { useEffect, useState } from "react";
import { useDyteClient } from '@dytesdk/react-web-core';
import { DyteMeeting } from '@dytesdk/react-ui-kit';
import { Socket } from "phoenix";

function App() {
  const values = window.location.pathname.split("/")
  const participant_id = values[3]
  const meeting_id = values[4]

  const socket = new Socket("/socket");
  socket.connect();
  
  var channel = socket.channel(`meeting:${meeting_id}`, {participant_id: participant_id})
  const [roomName, setRoomName] = useState(); 
  const [authToken, setAuthToken] = useState(); 
  const [meeting, initMeeting] = useDyteClient();
  
  const uiConfigOptions = {
    colors: {
      primary:         '#1D3557',
      secondary:       '#1D3557',
      textPrimary:     '#FFFFFF',
      videoBackground: '#FFFFFF'
    }}
    
    channel.join().receive("ignore", () => console.log("auth error"))
    .receive("ok", payload => console.log("join ok") )


    channel.on("after_join", response => {
      console.log("after_join")
      setRoomName(response.roomName)
      setAuthToken(response.authToken)
    })

    useEffect(() => {
      // initialise meeting object with same data you passed the component in older sdk 
      initMeeting({
        roomName: roomName,
        authToken: authToken
      })

      return () => {
        channel.leave()
      }

    }, [roomName, authToken]);

    useEffect(() => {
      if (!meeting) return;

      const onRoomJoined = () => {
        console.log('You have joined the room');
      };

      const onRoomLeft = () => {
        console.log('You have left the room');
        window.location = "/"
      };

      const onParticipantJoined = (participant) => {
        console.log(`${participant.name} has joined`);
      };

      meeting.self.addListener('roomJoined', onRoomJoined);
      meeting.self.addListener('roomLeft', onRoomLeft);
      meeting.participants.joined.addListener('participantJoined', onParticipantJoined);

      return () => {
        meeting.self.removeListener('roomJoined', onRoomJoined);
        meeting.self.removeListener('roomLeft', onRoomLeft);
        meeting.participants.joined.removeListener('participantJoined', onParticipantJoined);
      }
    }, [meeting]);

    return (
      <div className="App">
        <DyteMeeting
          uiConfig={uiConfigOptions}
          meeting={meeting}
          showSetupScreen
        />
      </div>
    );
}

export default App;


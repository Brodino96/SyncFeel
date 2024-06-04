let devices
let client

window.addEventListener("message", function(event) {
    let data = event.data
    switch (data.action) {
        
        case "vibrate":
            vibrate(data)
            break
            
        case "speeding":
            speeding(data)
            break

        case "connect":
            connectToy().catch(function () {
                fetch(`https://${GetParentResourceName()}/connectionError`, { method: "POST", body: JSON.stringify({})}).then(resp => console.log(resp))
            })
            break

        case "disconnect":
            client.disconnect()
            fetch(`https://${GetParentResourceName()}/disconnectSuccessful`, { method: "POST", body: JSON.stringify({})}).then(resp => console.log(resp))
            break
    }
})

async function vibrate(data) {
    console.log(`Intensity: ${data.intensity}, duration: ${data.duration}`)
    devices.forEach(device => {
        if (data.intensity > 0.0) {
            device.vibrate(data.intensity / 20)
        } else {
            device.stop()
        }
    })
    devices.forEach(device => {
        setTimeout(async () => {
            // And now we disconnect as usual
            await device.stop()
        }, 3000);
    })
    /*
    await new Promise(r => this.setTimeout(r, (data.duration * 1000)))
    devices.forEach(device => {
        device.stop()
    })*/
}

async function speeding(data) {
    //console.log(`You are speeding. Intensity: ${data.intensity}`)
    devices.forEach(device => {
        if (data.intensity > 0.0) {
            device.vibrate(data.intensity / 20)
        } else {
            device.stop()
        }
    })
}

async function connectToy() {
    let connector = new Buttplug.ButtplugBrowserWebsocketClientConnector("ws://127.0.0.1:12345");
    client = new Buttplug.ButtplugClient("Toy");
    await client.connect(connector);

    if (JSON.stringify(client.devices) == "[]") {

        await client.disconnect()
        fetch(`https://${GetParentResourceName()}/connectionError`, { method: "POST", body: JSON.stringify({})}).then(resp => console.log(resp))

    } else {

        devices = client.devices
        fetch(`https://${GetParentResourceName()}/connectionSuccess`, { method: "POST", body: JSON.stringify({})}).then(resp => console.log(resp))

        client.addListener("deviceremoved", () => {
            client.disconnect()
            fetch(`https://${GetParentResourceName()}/deviceDisconnected`, { method: "POST", body: JSON.stringify({})}).then(resp => console.log(resp))
        })
    }
}

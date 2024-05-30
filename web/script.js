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
                $.post(`https://${GetParentResourceName()}/connectionError`, JSON.stringify({}))
            })
            break

        case "disconnect":
            client.disconnect()
            $.post(`https://${GetParentResourceName()}/disconnectSuccessful`, JSON.stringify({}))
            break
    }
})

async function vibrate(data) {
    //console.log(`Intensity: ${data.intensity}, duration: ${data.duration}`)
    devices.forEach(device => {
        device.vibrate(data.intensity / 20)
    });
    await new Promise(r => this.setTimeout(r, (data.duration * 1000)))
    devices.forEach(device => {
        device.stop()
    });
}

async function speeding(data) {
    //console.log(`You are speeding. Intensity: ${data.intensity}`)
    devices.forEach(device => {
        if (data.intensity > 0.0) {
            device.vibrate(data.intensity / 20)
        } else {
            device.stop()
        }
    });
}

async function connectToy() {
    let connector = new Buttplug.ButtplugBrowserWebsocketClientConnector("ws://127.0.0.1:12345");
    client = new Buttplug.ButtplugClient("Toy");
    await client.connect(connector);

    if (JSON.stringify(client.devices) == "[]") {

        await client.disconnect()
        $.post(`https://${GetParentResourceName()}/connectionError`, JSON.stringify({}))

    } else {

        devices = client.devices
        $.post(`https://${GetParentResourceName()}/connectionSuccess`, JSON.stringify({}))

        client.addListener("deviceremoved", () => {
            client.disconnect()
            $.post(`https://${GetParentResourceName()}/deviceDisconnected`, JSON.stringify({}))
        })
    }
}

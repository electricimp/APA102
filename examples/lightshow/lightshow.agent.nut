function requestHandler(request, response) {
  try {
    if ("glow" in request.query) {
      device.send("seteffect", 0);
      response.send(200, "Glow effect on");
      return;
    }

    if ("random" in request.query) {
      device.send("seteffect", 1);
      response.send(200, "Random effect on");
      return;
    }

    if ("looper" in request.query) {
      device.send("seteffect", 2);
      response.send(200, "Looper effect on");
      return;
    }

    if ("larson" in request.query) {
      device.send("seteffect", 3);
      response.send(200, "Larson effect on");
      return;
    }

    if ("setcolor" in request.query) {
      device.send("setcolor", request.query.setcolor);
      response.send(200, "Color set");
      return;
    }

    response.send(200, "Waiting for a command");

  } catch (error) {
    server.log("Error: " + error);
  }
}
 
// Reqister the handler to deal with incoming requests
 
http.onrequest(requestHandler);
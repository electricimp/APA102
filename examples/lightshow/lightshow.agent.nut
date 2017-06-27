// MIT License
//
// Copyright (c) 2016-17 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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
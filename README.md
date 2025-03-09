# Platform.Challenge
 Technical Challenge for Platform Engineering

[Challenge Instructions](https://github.com/shepz/platform-engineer-challenge)

Additionally, I have stablished the next scenario / requirements that helps me to implement and test the instructions provided in the Challenge Instructions.

A software company, with offices in Quebec, Montreal and Mexico City is planning to hire several developers in all locations. 
The software this company builds has a strong dependency on an API, every single developer working for the company will need to have access to this API for development purposes. Since language changes depending on location, the software company needs this dependency API to work under the next setup:
* Quebec = French
* Montreal = English
* Mexico = Spanish
  
**Requirement:** Deploy this API, 3 times, one per office. The API uses the right language, depending on location.

**Image:** https://hub.docker.com/repository/docker/benswengineer/helloer/general
*helloer is a little hello world api*

 Additionally, the developers working for the software company follow a management hierarchy, which includes:
* Junior developers:

  It is expected that junior developers only have list/get permissions for pod and deployment resources applied only to their current office.
* Senior developers:

  It is expected that Senior developers have list/get permissions for pod, deployment, service and secret resources applied to their current office and another office.
* Lead developers:

  It is expected that Lead developers have list/get/create/delete/scale permissions for pod, deployment, service and secret resources applied to all offices.

# SceneKit-Occlusion
Sample project demonstrating virtual object environmental occlusion using ARKit &amp; SceneKit

### Background

As we know in iOS SceneKit does not provide environment occlusion while RealityKit does. So this is manual implementation of environmental object occlusion via SceneKit in iOS

### How it works

Firs we configure AR with mesh scene reconstruction (i.e. this is only available in Lidar enabled devices). Then whenever we get AR Mesh in 'renderer' method, we turn that mesh geometery into Node, and apply occlusion material to that node. With rendering order less then of our virtual objects, it is insured these nodes are rendered before our virtual content and occlude them on interaction.

//
//  ViewController.swift
//  SceneKit-Occlusion
//
//  Created by haris abid on 30/01/2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //creating a simple node of box shape
        let boxGeometery = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        boxGeometery.firstMaterial?.diffuse.contents = UIColor.red
        let boxNode = SCNNode(geometry: boxGeometery)
        
        //placing it in front of camera with 1 meter away from it
        boxNode.position = SCNVector3(0, 0, -1)
        
        // Set the scene to the view
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        //Before starting session, put this option in configuration
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
        } else {
                // Handle device that doesn't support scene reconstruction
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let meshAnchor = anchor as? ARMeshAnchor else {
                return nil
            }

        let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)

        //apply occlusion material
        geometry.firstMaterial?.colorBufferWriteMask = []
        geometry.firstMaterial?.writesToDepthBuffer = true
        geometry.firstMaterial?.readsFromDepthBuffer = true
            

        let node = SCNNode(geometry: geometry)
        //change rendering order so it renders before  our virtual object
        node.renderingOrder = -1
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let meshAnchor = anchor as? ARMeshAnchor else {
                return
            }
        let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)

            // Optionally hide the node from rendering as well
            geometry.firstMaterial?.colorBufferWriteMask = []
            geometry.firstMaterial?.writesToDepthBuffer = true
            geometry.firstMaterial?.readsFromDepthBuffer = true
            

        node.geometry = geometry
    }
    
    // Taken from https://developer.apple.com/forums/thread/130599
    func createGeometryFromAnchor(meshAnchor: ARMeshAnchor) -> SCNGeometry {
        let meshGeometry = meshAnchor.geometry
        let vertices = meshGeometry.vertices
        let normals = meshGeometry.normals
        let faces = meshGeometry.faces
        
        // use the MTL buffer that ARKit gives us
        let vertexSource = SCNGeometrySource(buffer: vertices.buffer, vertexFormat: vertices.format, semantic: .vertex, vertexCount: vertices.count, dataOffset: vertices.offset, dataStride: vertices.stride)
        
        let normalsSource = SCNGeometrySource(buffer: normals.buffer, vertexFormat: normals.format, semantic: .normal, vertexCount: normals.count, dataOffset: normals.offset, dataStride: normals.stride)
        // Copy bytes as we may use them later
        let faceData = Data(bytes: faces.buffer.contents(), count: faces.buffer.length)
        
        // create the geometry element
        let geometryElement = SCNGeometryElement(data: faceData, primitiveType: primitiveType(type: faces.primitiveType), primitiveCount: faces.count, bytesPerIndex: faces.bytesPerIndex)
        
        return SCNGeometry(sources: [vertexSource, normalsSource], elements: [geometryElement])
    }

    func primitiveType(type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
            switch type {
                case .line: return .line
                case .triangle: return .triangles
            default : return .triangles
            }
    }
    
}

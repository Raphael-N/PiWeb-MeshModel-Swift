//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import SceneKit

class MeshModelMeshNode: SCNNode {
    private let maximumPointsPerNode = 50000
    private let material = SCNMaterial()
    
    override static public var supportsSecureCoding: Bool {
        return true
    }
    
    convenience init(meshes: [MeshModelMesh]) {
        self.init()
        
        let nodes = SCNNode()
        var positionCount = 0
        guard let color = meshes.first?.color else {
            return
        }
        material.isDoubleSided = true
        material.diffuse.contents = UIColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: CGFloat(color.w))
        for mesh in meshes {
            if positionCount + mesh.positions.count > maximumPointsPerNode {
                
                addChildNode(nodes.flattenedClone())
                nodes.childNodes.forEach { $0.removeFromParentNode() }
                positionCount = 0
            }
            
            nodes.addChildNode(createNode(mesh: mesh))
            
            positionCount += mesh.positions.count
        }
        
        if !nodes.childNodes.isEmpty {
            self.addChildNode(nodes.flattenedClone())
        }
    }
    
    private func toInteger(color: SCNVector4) -> Int {
        return Int(color.x * 255.0) | Int(color.y * 255.0) << 8 | Int(color.z * 255.0) << 16 | Int(color.w * 255.0) << 24
    }
    
    func createNode(mesh: MeshModelMesh) -> SCNNode {
        var indizes: [Int32] = mesh.indizes
        
        let indexData = Data(bytes: &indizes, count: MemoryLayout<Int32>.size * indizes.count)
        let positionSource = SCNGeometrySource(vertices: mesh.positions)
        let normalSource = SCNGeometrySource(normals: mesh.normals)
        
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .triangles,
            primitiveCount: indizes.count / 3,
            bytesPerIndex: MemoryLayout<Int32>.size)
        
        let geo = SCNGeometry(sources: [positionSource, normalSource], elements: [element])
        geo.materials = [material]
        
        return SCNNode(geometry: geo)
    }
}

// http://waynewbishop.com/swift/graphs/dijkstra/
// https://github.com/nilotic/Undirected-Dijkstra-Swift

final class Vertex {
    var key: String?
    var neighbors = [Edge]()
}

final class Edge {
    var neighbor = Vertex()
    var weight   = 0
    var visited  = false
}

final class Path {
    var total: Int!
    var destination = Vertex()
    var previous: Path!
}

final class SwiftGraph {

    private var canvas = [Vertex]()
    var isDirected     = false
    
    // Create a new vertex
    func addVertex(key: String) -> Vertex {
        // Set the key
        let childVertex = Vertex()
        childVertex.key = key
        
        // Add the vertex to the graph canvas
        canvas.append(childVertex)
        return childVertex
    }
    
    func addEdge(source: Vertex, neighbor: Vertex, weight: Int) {
        // Create a new edge
        let newEdge = Edge()
        
        // Establish the default properties
        newEdge.neighbor    = neighbor
        newEdge.weight      = weight
        newEdge.visited     = false
        source.neighbors.append(newEdge)
        
        // Check for undirected graph
        if (isDirected == false) {
            // Create a new reversed edge
            let reverseEdge = Edge()
            
            // Establish the reversed properties
            reverseEdge.neighbor = source
            reverseEdge.weight   = weight
            reverseEdge.visited  = false
            neighbor.neighbors.append(reverseEdge)
        }
    }
    
    func processDijkstra(source: Vertex, destination: Vertex) -> Path? {
        var frontier   = [Path]()
        var finalPaths = [Path]()
        
        // source.visited = false ?!?! dont need it
        
        // Use source edges to create the frontier
        for edge in source.neighbors {
            let newPath: Path = Path()
            newPath.destination = edge.neighbor
            newPath.previous    = nil
            newPath.total       = edge.weight
            edge.visited        = true
            
            // Add the new path to the frontier
            frontier.append(newPath)
        }
        
        // Obtain the best path
        var bestPath = Path()
        while(frontier.count != 0) {
            // Support path changes using the greedy approach
            bestPath      = Path()
            var pathIndex = 0
            
            for index in 0..<frontier.count {
                let itemPath = frontier[index]
                if (bestPath.total == nil) || (itemPath.total < bestPath.total) {
                    bestPath  = itemPath
                    pathIndex = index
                }
            }
            
            for edege in bestPath.destination.neighbors {
                let newPath = Path()
                
                if (edege.visited == false) {
                    edege.visited       = true
                    newPath.destination = edege.neighbor
                    newPath.previous    = bestPath
                    newPath.total       = bestPath.total + edege.weight
                    
                    // Add the new path to the frontier
                    frontier.append(newPath)
                }
            }
            
            // Preserve the bestPath
            finalPaths.append(bestPath)
            
            // Remove the bestPath from the frontier
            frontier.removeAtIndex(pathIndex)
        }
        
        for path in finalPaths {
            if (path.total < bestPath.total) && (path.destination.key == destination.key) {
                bestPath = path
            }
        }
        
        return bestPath
    }
}

extension SwiftGraph {
    /*
    
     
     printSeperator("FINALPATHS")
     printPaths(finalPaths as [Path], source: source)
     printSeperator("BESTPATH BEFORE")
     printPath(bestPath, source: source)
     for path in finalPaths {
     if (path.total < bestPath.total) && (path.destination.key == destination.key){
     bestPath = path
     }
     }
     printSeperator("BESTPATH AFTER")
     printPath(bestPath, source: source)
 */
    func printPath(path: Path, source: Vertex) {
        print("BP: weight- \(path.total) \(path.destination.key!) ")
        if path.previous != nil {
            printPath(path.previous!, source: source)
        } else {
            print("Source : \(source.key!)")
        }
    }
    
    func printPaths(paths: [Path], source: Vertex) {
        for path in paths {
            printPath(path, source: source)
        }
    }
    
    func printLine() {
        print("*******************************")
    }
    
    func printSeperator(content: String) {
        printLine()
        print(content)
        printLine()
    }

}

///* TEST 1
///* Wikipedia Undirected Dijkstra graph
///* Link: https://en.wikipedia.org/wiki/Dijkstra's_algorithm

var graph = SwiftGraph()

var A = graph.addVertex("A")
var B = graph.addVertex("B")
var C = graph.addVertex("C")
var D = graph.addVertex("D")
var E = graph.addVertex("E")

graph.addEdge(A, neighbor: B, weight: 1)
graph.addEdge(B, neighbor: C, weight: 2)
graph.addEdge(B, neighbor: D, weight: 5)
graph.addEdge(A, neighbor: D, weight: 4)
graph.addEdge(D, neighbor: E, weight: 8)

var path = graph.processDijkstra(D, destination: E)
path?.total

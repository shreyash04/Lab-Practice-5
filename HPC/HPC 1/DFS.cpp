#include <iostream>
#include <vector>
#include <queue>
#include <stack>
#include <omp.h>

using namespace std;
class Graph{
    public:
    int V;
    vector<vector<int>> adj;
    Graph(int v):  V(v),adj(v){}
    void addedge(int u,int v){
        adj[u].push_back(v);
        adj[v].push_back(u);
    }
    void DFS(int start) {
        // initialize visited and stack
        vector<bool> visited(V, false);
        stack<int> s;
        //visited[start] = true;
        s.push(start);
        while (!s.empty()) {
            int curr_node = s.top();
        	//cout << curr_node << " ";
            s.pop();
        	if (!visited[curr_node]) {
                visited[curr_node]=true;
        	    cout << curr_node << " ";
            // parallelize the loop over the neighbors of the current node
                #pragma omp parallel for
                for (int i = 0; i < adj[curr_node].size(); i++) {
                    int u = adj[curr_node][i];
                    if (!visited[u]) {
                        s.push(u);
                    }
                }
            }
        }
    }
};
int main(){
    int v;
    cout<<"Enter The number of vertices: ";
    cin>>v;
    Graph g(v);
    int e;
    cout<<"\nEnter The number of edges: ";
    cin>>e;
    int start;
    for (int i=0;i<e;i++){
        int u,v;
        cout<<"Enter start and end vertex:";
        cin>>u>>v;
        g.addedge(u,v);
    }
    cout<<"\n Enter Starting Node:";
    cin>>start;
    cout<<"\nDFS starting from node "<<start<<":\n";
    g.DFS(start);
    return 0;
}

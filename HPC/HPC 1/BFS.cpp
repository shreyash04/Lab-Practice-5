#include <iostream>
#include <vector>
#include <queue>
#include <stack>
#include <omp.h>

using namespace std;
class Graph{
    public:
    int v;
    vector<vector<int>> adj;
    Graph(int v):v(v),adj(v){}
    void addedge(int u,int v){
        adj[u].push_back(v);
        adj[v].push_back(u);
    }
    void BFS(int start){
        vector<bool> visited(v,false);
        queue<int> q;
        visited[start]=true;
        q.push(start);
        while (!q.empty()){
            int curr_node = q.front();
            q.pop();
            cout << curr_node << " ";
            #pragma omp parallel for
            for (int i = 0; i < adj[curr_node].size(); i++) {
                int neighbor = adj[curr_node][i];
                if (!visited[neighbor]) {
                    visited[neighbor] = true;
                    q.push(neighbor);
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
    cout<<"\nBFS starting from node "<<start<<":\n";
    g.BFS(start);
    return 0;
}
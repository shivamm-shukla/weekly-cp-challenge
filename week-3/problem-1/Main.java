import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

public class Main {

  static void dfs(List<List<Integer>> adj, boolean[] visited, int start){
      visited[start] = true;
      
      for (int nei : adj.get(start)){
        if (!visited[nei]) dfs(adj, visited, nei);
      }
  }

  static List<Integer> solve(List<List<Integer>> adj, int start){
      List<Integer> res = new ArrayList<>();
      boolean[] visited = new boolean[adj.size()];
      dfs(adj, visited, start);

      for (int i = 1; i < visited.length; i++){
        if (!visited[i]) res.add(i);
      }

      return res;
  }
  public static void main(String[] args)throws Exception{
      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      StringTokenizer st = new StringTokenizer(br.readLine());
      int n = Integer.parseInt(st.nextToken());
      int m = Integer.parseInt(st.nextToken());

      List<List<Integer>> adj = new ArrayList<>();
      for (int i = 0; i <= n; i++){
        adj.add(new ArrayList<>());
      }

      for (int i = 0; i < m; i++){
        st = new StringTokenizer(br.readLine());
        int a = Integer.parseInt(st.nextToken());
        int b = Integer.parseInt(st.nextToken());
        
        adj.get(a).add(b);
        adj.get(b).add(a);
      }

      List<Integer> res = solve(adj, 1);
      int k = res.size();
      System.out.println(k);
      if (k > 0){
        for (int i = 0; i < k; i++){
          System.out.print(res.get(i)+" ");
        }
      }
  }
}

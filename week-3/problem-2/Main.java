import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Main {
   public static void main(String[] args) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        String[] first = br.readLine().split(" ");
        int R = Integer.parseInt(first[0]);
        int C = Integer.parseInt(first[1]);

        char[][] grid = new char[R][C];

        for (int i = 0; i < R; i++) {
            String s = br.readLine();
            grid[i] = s.toCharArray();
        }

        System.out.println(solve(grid, R, C));
    }

    static int solve (char[][] grid, int m, int n){
        int c = 0;
        boolean[][] visited = new boolean[m][n];

        for (int i = 0; i < m; i++){
          for (int j = 0; j < n; j++){
            if (grid[i][j] != '#' && !visited[i][j]){

                int[] count = new int[2];
                dfs(grid, visited, count, i, j);
                 if (count[0] > 0 && count[1] == 0) c++;
            }
          }
        }

      return c;
    }

    static void dfs(char[][] grid, boolean[][] visited, int[] count, int i, int j){
        visited[i][j] = true;
        if (grid[i][j] == 'L') count[0]++;
        if (grid[i][j] == 'G') count[1]++;

        int[] drow = {-1, 0, 1, 0};
        int[] dcol = {0, 1, 0, -1};

        for (int k = 0; k < 4; k++){
          int nrow = i + drow[k];
          int ncol = j + dcol[k];

          if (nrow >= 0 && nrow < grid.length && ncol >= 0 && ncol < grid[0].length && grid[nrow][ncol] != '#' && !visited[nrow][ncol]){
              dfs(grid, visited, count, nrow, ncol);
          }

        }
    }
}

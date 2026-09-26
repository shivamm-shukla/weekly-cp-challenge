import java.io.*;
import java.util.*;

public class Main {

    static int R, C;
    static int[][] grid;
    static boolean[][] visited;

    static class Cell {
        int aura;
        int row;
        int col;

        Cell(int aura, int row, int col) {
            this.aura = aura;
            this.row = row;
            this.col = col;
        }
    }

    static long solve(int sr, int sc, long c0) {

        long confidence = c0;

        PriorityQueue<Cell> pq =
            new PriorityQueue<>((a, b) -> Integer.compare(a.aura, b.aura));

        int[] dr = {-1, 0, 1, 0};
        int[] dc = {0, 1, 0, -1};

        visited[sr][sc] = true;

        for (int k = 0; k < 4; k++) {

            int nr = sr + dr[k];
            int nc = sc + dc[k];

            if (nr >= 1 && nr <= R &&
                nc >= 1 && nc <= C &&
                !visited[nr][nc]) {

                visited[nr][nc] = true;

                pq.add(new Cell(
                    grid[nr][nc],
                    nr,
                    nc
                ));
            }
        }

        while (!pq.isEmpty()) {

            Cell current = pq.peek();

            // If the smallest aura is not affordable,
            // no other boundary cell can be affordable either.
            if ((long) current.aura >= confidence) {
                break;
            }

            pq.poll();

            // Talk to this senior.
            confidence += current.aura;

            int row = current.row;
            int col = current.col;

            for (int k = 0; k < 4; k++) {

                int nr = row + dr[k];
                int nc = col + dc[k];

                if (nr >= 1 && nr <= R &&
                    nc >= 1 && nc <= C &&
                    !visited[nr][nc]) {

                    visited[nr][nc] = true;

                    pq.add(new Cell(
                        grid[nr][nc],
                        nr,
                        nc
                    ));
                }
            }
        }

        return confidence;
    }

    public static void main(String[] args) throws Exception {

        BufferedReader br =
            new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st =
            new StringTokenizer(br.readLine());

        R = Integer.parseInt(st.nextToken());
        C = Integer.parseInt(st.nextToken());
        long c0 = Long.parseLong(st.nextToken());

        st = new StringTokenizer(br.readLine());

        int sr = Integer.parseInt(st.nextToken());
        int sc = Integer.parseInt(st.nextToken());

        // 1-based indexing
        grid = new int[R + 1][C + 1];
        visited = new boolean[R + 1][C + 1];

        for (int i = 1; i <= R; i++) {

            st = new StringTokenizer(br.readLine());

            for (int j = 1; j <= C; j++) {
                grid[i][j] = Integer.parseInt(st.nextToken());
            }
        }

        System.out.println(solve(sr, sc, c0));
    }
}
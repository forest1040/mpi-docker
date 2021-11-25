#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // MPIを初期化
    MPI_Init(NULL, NULL);

    // 全プロセス数 (≒クラスタ内のコア数) を取得
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // このプロセスのランク (プロセスID) を取得
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // このノードのホスト名を取得
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Hello worldを出力
    printf("Hello world from processor %s, rank %d out of %d processors\n",
           processor_name, world_rank, world_size);

    // MPIを終了
    MPI_Finalize();
}

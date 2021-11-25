# mptensor の docker マルチノードでのサンプル実行

## ソースコード

- [mptensor](https://github.com/smorita/mptensor.git)
- [docker.openmpi](https://github.com/oweidner/docker.openmpi)

## 実行方法

- mptensor のサンプルの２次元イジングモデルを実行
  ```sh
  $ make example
  ```
- mptensor のテストを実行
  ```sh
  $ make test
  ```

## 環境

docker-compose を使用して、サブネット`172.30.100.0/24`に以下のノードを作成します。

- mpi-docker_mpi_head_1: OpenMPI のマスタノード
- mpi-docker_mpi_node_1: OpenMPI のスレイブノード 1
- mpi-docker_mpi_node_2: OpenMPI のスレイブノード 2

mpi4py_benchmarks/hosts 上に OpenMPI で通信するサーバ IP を指定しています。
IP を変更する場合はこちらも修正してください。
docker-compose の scale でノード数を変更する場合も同様に変更してください。

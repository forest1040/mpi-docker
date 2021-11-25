AUTH=forest1040
NAME=mpi_docker
TAG=${NAME}

.DEFAULT_GOAL := help

help:
	@echo "Use \`make <target>\` where <target> is one of"
	@echo "  help     display this help message"
	@echo "  build   build from Dockerfile"
	@echo "  rebuild rebuild from Dockerfile (ignores cached layers)"
	@echo "  main    build and docker-compose the whole thing"

build:
	docker build -t $(TAG) .

rebuild:
	docker build --no-cache -t $(TAG) .

main:
	# 2 worker nodes
	docker-compose up -d --scale mpi_node=2
	docker-compose exec --privileged mpi_head sudo -u mpirun mpirun --hostfile /home/mpirun/mpi4py_benchmarks/hosts -n 2 python3 /home/mpirun/mpi4py_benchmarks/all_tests.py
	docker-compose down

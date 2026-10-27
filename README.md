# AutoDock Vina Docker image

This image builds the `vina` and `vina_split` command line programs from a
pinned commit of [forlilab/AutoDock-Vina](https://github.com/forlilab/AutoDock-Vina).
It runs on Linux containers. The Python bindings are not included.
Python 3 is included for running scripts that call the Vina executables.

## Get the repository

This project is published at [github.com/rontu1997/autodock](https://github.com/rontu1997/autodock).

```sh
git clone https://github.com/rontu1997/autodock.git
cd autodock
```

## PSC manifest

[autodock-vina-tool.json](autodock-vina-tool.json) describes a Python code
environment that reads prepared inputs from `/app/inputs` and saves results
under `/work`. Its ACR image name is a target tag; the image has not been
pushed to that registry. Publish the rebuilt image under the manifest's
`infra[0].image.acr` value before deploying the manifest.

## Tested docking example

The `example-data` directory contains the prepared c-Abl receptor, imatinib
ligand, and docking box from the [official basic docking example](https://github.com/forlilab/AutoDock-Vina/tree/bb64e5e26b520569a86360d69248069b5e665b3f/example/basic_docking/solution).
Run the same calculation from PowerShell:

```powershell
docker run --rm --mount type=bind,source=${PWD}\example-data,target=/data autodock-vina --receptor 1iep_receptor.pdbqt --ligand 1iep_ligand.pdbqt --config 1iep_receptor.box.txt --exhaustiveness 32 --cpu 4 --seed 42 --out docked.pdbqt
```

The best pose in this run scored **-13.25 kcal/mol** with Vina's scoring
function. The poses are in `example-data/docked.pdbqt`, and the full score
table is in `example-data/docking.log`. This is a predicted docking score,
not an experimentally measured binding affinity.

## Build

```sh
docker build -t autodock-vina .
```

## Run

Show the Vina options:

```sh
docker run --rm autodock-vina
```

Put receptor and ligand PDBQT files in a local `data` directory, then mount
that directory at `/data`. Paths passed to Vina are relative to `/data`.
For PowerShell:

```powershell
docker run --rm -v "${PWD}\data:/data" autodock-vina --receptor receptor.pdbqt --ligand ligand.pdbqt --center_x 0 --center_y 0 --center_z 0 --size_x 20 --size_y 20 --size_z 20 --out docked.pdbqt
```

For Bash:

```sh
docker run --rm -v "$(pwd)/data:/data" autodock-vina \
  --receptor receptor.pdbqt --ligand ligand.pdbqt \
  --center_x 0 --center_y 0 --center_z 0 \
  --size_x 20 --size_y 20 --size_z 20 --out docked.pdbqt
```

Set the center and box sizes for your actual binding site. The output appears
in the local `data` directory.

To run `vina_split`, override the entrypoint:

```sh
docker run --rm --entrypoint vina_split autodock-vina --help
```

On Linux, the container runs as UID 10001. If your mounted directory needs
your own UID and GID to write files, add `--user "$(id -u):$(id -g)"` to
`docker run`.

The source commit is set by `VINA_COMMIT` in the Dockerfile. To build another
commit, pass `--build-arg VINA_COMMIT=<full-commit-sha>`.

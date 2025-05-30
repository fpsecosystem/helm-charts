# Simple App Example

This example demonstrates how to use the `mariadb-library-chart` as a dependency in your own Helm chart.

## Usage

1. Update the dependency repository URL in `Chart.yaml` to point to your actual repository
2. Update the dependency and build:

```bash
helm dependency update
helm dependency build
```

3. Install the chart:

```bash
helm install my-app . --namespace my-namespace --create-namespace
```

## Configuration

The MariaDB library chart configuration is nested under the `mariadb-library-chart` key in `values.yaml`.

This example will create:
- A database named `simple-app-db`
- A user named `simple-app-user` with a randomly generated password
- Appropriate grants for the user on the database

## Prerequisites

- MariaDB Operator installed in your cluster
- A MariaDB instance named `mariadb-instance` in the `mariadb-system` namespace

Adjust the `mariaDbRef` values in `values.yaml` to match your actual MariaDB instance.

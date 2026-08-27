# terraform-aws-s3

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-s3?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-s3?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates S3 related resources on AWS.

- [access-grants-grant](./modules/access-grants-grant)
- [access-grants-instance](./modules/access-grants-instance)
- [access-grants-location](./modules/access-grants-location)
- [access-point](./modules/access-point)
- [bucket](./modules/bucket)
- [objects](./modules/objects)
- [table](./modules/table)
- [table-bucket](./modules/table-bucket)
- [vector-bucket](./modules/vector-bucket)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-s3) were written to manage the following AWS Services with Terraform.

- **AWS S3**
  - S3 Bucket
  - S3 Access Grants
    - Instance
    - Location
    - Grant
  - S3 Access Point
  - S3 Object
  - S3 Tables
    - Table Bucket
    - Namespace
    - Table
  - S3 Vectors
    - Vector Bucket
    - Vector Index


## Examples

### S3 Bucket

- [Full S3 Bucket](./examples/bucket-full)
- [S3 Bucket with Access Logging](./examples/bucket-access-logging)
- [S3 Bucket with Server-Side Encryption](./examples/bucket-encryption)
- [S3 Bucket with Lifecycle Rules](./examples/bucket-lifecycle-rules)
- [S3 Bucket with Objects](./examples/bucket-objects)
- [S3 Bucket with Versioning](./examples/bucket-versioning)

### S3 Access Grants

- [S3 Access Grants](./examples/access-grants)

### S3 Access Point

- [S3 Access Point (Internet Access)](./examples/access-point-internet)
- [S3 Access Point (VPC Access)](./examples/access-point-vpc)

### S3 Tables

- [S3 Table Bucket with Table](./examples/table-bucket)

### S3 Vectors

- [S3 Vector Bucket](./examples/vector-bucket)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-s3). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022-2026, [Byungjin Park](https://www.posquit0.com).

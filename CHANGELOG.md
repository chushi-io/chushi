# Changelog

All notable changes to this project will be documented in this file.

### [1.10.1](https://github.com/chushi-io/chushi/compare/v1.10.0...v1.10.1) (2024-04-11)


### Bug Fixes

* **driver:** Stub out driver tests, refactor interfaces ([29fa993](https://github.com/chushi-io/chushi/commit/29fa993766d724dae5d894626cb0064499f3132e))

## [1.10.0](https://github.com/chushi-io/chushi/compare/v1.9.0...v1.10.0) (2024-04-09)


### Features

* **driver:** Add swappable drivers ([677e28c](https://github.com/chushi-io/chushi/commit/677e28cd14a9eb79e0a925660dd2d961cd572685))

## [1.9.0](https://github.com/chushi-io/chushi/compare/v1.8.3...v1.9.0) (2024-04-03)


### Features

* **migrations:** Move to migrations library ([0f10ee6](https://github.com/chushi-io/chushi/commit/0f10ee6b382caa2f71c88032c9e8ba1ca1c0890b))

### [1.8.3](https://github.com/chushi-io/chushi/compare/v1.8.2...v1.8.3) (2024-04-03)


### Bug Fixes

* **migrations:** Reorder ([cfb36d5](https://github.com/chushi-io/chushi/commit/cfb36d53bbdb0cf406049f46ed5b7073730e1b25))

### [1.8.2](https://github.com/chushi-io/chushi/compare/v1.8.1...v1.8.2) (2024-04-03)


### Bug Fixes

* **docker:** Fix entrypoint for Docker image ([1f91379](https://github.com/chushi-io/chushi/commit/1f91379f83653dfac98d2f8ddfa8337c42acb8ba))

### [1.8.1](https://github.com/chushi-io/chushi/compare/v1.8.0...v1.8.1) (2024-04-02)


### Bug Fixes

* **ci:** Fix lint steps, fix helm publish ([cf53277](https://github.com/chushi-io/chushi/commit/cf532771216a7f2b0fe6bb5f6b3d47b46b2d3d56))

## [1.8.0](https://github.com/chushi-io/chushi/compare/v1.7.1...v1.8.0) (2024-04-02)


### Features

* **helm:** Add helm chart ([bd0900f](https://github.com/chushi-io/chushi/commit/bd0900f76dc2615df3a8572fa48848e0ea454094))


### Bug Fixes

* **helm:** Adjust CI jobs ([aff91d8](https://github.com/chushi-io/chushi/commit/aff91d831e0c2c42e7dbf7e3b71b6457c1b475df))
* **helm:** Fix chart name ([302632d](https://github.com/chushi-io/chushi/commit/302632d01d5f052d4b2bdcbc7ba778336d41c61a))

### [1.7.1](https://github.com/chushi-io/chushi/compare/v1.7.0...v1.7.1) (2024-02-29)


### Bug Fixes

* **runs:** Return response for grpc runs request ([a6b41c1](https://github.com/chushi-io/chushi/commit/a6b41c1c293beeaa8a26aae6a876a30ef56ebfc0))

## [1.7.0](https://github.com/chushi-io/chushi/compare/v1.6.0...v1.7.0) (2024-02-29)


### Features

* **agent:** All agent requests now go over GRPC ([5804090](https://github.com/chushi-io/chushi/commit/58040904a93f4aaa43f09245f99aeff0b5ffe7f9))

## [1.6.0](https://github.com/chushi-io/chushi/compare/v1.5.0...v1.6.0) (2024-02-20)


### Features

* **auth:** Generate runner tokens, and verify them on state operations ([3cab7b1](https://github.com/chushi-io/chushi/commit/3cab7b1520ca6af0c2bf3764bb41a80dd9fb251b))

## [1.5.0](https://github.com/chushi-io/chushi/compare/v1.4.0...v1.5.0) (2024-02-18)


### Features

* **grpc:** Add GRPC endpoints for receiving run requests ([26b6e0c](https://github.com/chushi-io/chushi/commit/26b6e0c7c2152d1d709f832d92918055d795323b))

## [1.4.0](https://github.com/chushi-io/chushi/compare/v1.3.0...v1.4.0) (2024-02-18)


### Features

* **variable_sets:** Add variable sets ([5c4fcc1](https://github.com/chushi-io/chushi/commit/5c4fcc13e2117b545d43a7a9b3ba09c15737294a))

## [1.3.0](https://github.com/chushi-io/chushi/compare/v1.2.2...v1.3.0) (2024-02-17)


### Features

* **variables:** Add V1 support for variables ([2a49dbd](https://github.com/chushi-io/chushi/commit/2a49dbdada81eb95232e733bb9cd4cf412deeb70))

### [1.2.2](https://github.com/chushi-io/chushi/compare/v1.2.1...v1.2.2) (2024-02-16)


### Bug Fixes

* **sdk:** Upgrade to use sling ([e79a89a](https://github.com/chushi-io/chushi/commit/e79a89a694cc3454f8626f021e795da4ec437497))

### [1.2.1](https://github.com/chushi-io/chushi/compare/v1.2.0...v1.2.1) (2024-02-15)


### Bug Fixes

* **storage:** Auto create buckets if they dont exist ([3b4c080](https://github.com/chushi-io/chushi/commit/3b4c080a2c3c9cf05b8c478f3ace76f8788b8449))
* **vcs:** Add configuration for VCS connections ([415be11](https://github.com/chushi-io/chushi/commit/415be11f3b7bc1caa42b491a3b8e1f8ec37348b5))

## [1.2.0](https://github.com/chushi-io/chushi/compare/v1.1.0...v1.2.0) (2024-02-14)


### Features

* **ui:** Agent and workspace creation added ([0948b3b](https://github.com/chushi-io/chushi/commit/0948b3b2a3a29592d0920b0730879135d4a91745))

## [1.1.0](https://github.com/chushi-io/chushi/compare/v1.0.3...v1.1.0) (2024-02-13)


### Features

* **org:** Add organization selection ([94dd7df](https://github.com/chushi-io/chushi/commit/94dd7df27aca30479582dfd45935081a5c88c97d))
* **orgs:** Auto create user org, add UI provider for viewing organizations ([7c84014](https://github.com/chushi-io/chushi/commit/7c840142734b4730d399334a87cd5515cff91d44))

### [1.0.3](https://github.com/chushi-io/chushi/compare/v1.0.2...v1.0.3) (2024-02-13)


### Bug Fixes

* **orgs:** Add route for me/orgs to get organizations for current user ([50b7f32](https://github.com/chushi-io/chushi/commit/50b7f32b7f4abe9bf61f7e2525cf241256aa7a00))

### [1.0.2](https://github.com/chushi-io/chushi/compare/v1.0.1...v1.0.2) (2024-02-13)


### Bug Fixes

* **mod:** Update mod path to new repository ([78d23e7](https://github.com/chushi-io/chushi/commit/78d23e7766e050e3324ce92686394df3977c57a6))

### [1.0.1](https://github.com/chushi-io/chushi/compare/v1.0.0...v1.0.1) (2024-02-07)


### Bug Fixes

* **ci:** Add packages:write permissions to default token permissions ([dae111c](https://github.com/chushi-io/chushi/commit/dae111ca2b026aaf977be0a9b73da36e68f0e7f5))

## 1.0.0 (2024-02-06)


### Bug Fixes

* **ci:** Add .releaserc.json ([699ca5e](https://github.com/chushi-io/chushi/commit/699ca5e375e0df14aba96b4dcea35225a01c1d73))
* **ci:** Initialize semantic-release ([816e416](https://github.com/chushi-io/chushi/commit/816e416bc4d2d3e61893afcd61ac2f6888e5f940))

# HTTPLib

HTTPLib is a Swift library that provides a flexible and modular approach to data fetching via HTTP. It aims to simplify the process of working with HTTP requests and responses, while also offering native support for JSON Codable serialization.

## Key Features

- **DataProvider Protocol**: The library introduces the `DataProvider` protocol, allowing you to decouple data fetching logic from your API instances. This enables easy mocking of results and enhances testability without relying on external libraries.

- **HTTPDataProvider Integration**: The `DataProvider` protocol seamlessly integrates HTTP data fetching functionality. It eliminates the need for a separate `HTTPDataProvider` class by providing a unified approach to sending requests and handling responses.

- **JSON Codable Support**: HTTPLib now natively supports JSON Codable serialization. This means you can easily encode and decode requests and responses using JSON, making it convenient to work with APIs that utilize JSON as the data format. The library provides protocols and structs, such as `DataProviderRequest` and `EncodableDataProviderRequest`, to simplify the process of working with structured data.

## Getting Started

### Requirements

- Swift 5.0+
- iOS 9.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 12.0+

### Installation

You can install HTTPLib using Swift Package Manager. Simply add it as a dependency in your `Package.swift` file:

```swift
dependencies: [
	 .package(url: "https://github.com/jaderfeijo/httplib.git", .upToNextMajor(from: "1.0.0"))
]
```

### Usage

Here's a simple example demonstrating how to use HTTPLib to send an HTTP request:

```swift
import HTTPLib

// Create a data provider instance
let dataProvider: DataProvider = HTTPDataProvider()

// You can also specify a custom JSONDecoder
let customDataProvider: DataProvider = HTTPDataProvider(
	decoder: JSONDecoder())

// Define a request
let request = RawDataProviderRequest(
	 method: .get,
	 url: "https://api.example.com/users")

do {
	// Send the request and handle the response
	let response: MyModel = try await dataProvider.send(request)
	
	// Handle the successfully parsed response
	print("Response: \(response)")
} catch {
	switch error {
    case .unreachable:
        print("Error: Unable to reach the data provider.")
    case .service(let code, let data):
        print("Error: Service error with status code \(code.rawValue).")
        print("Response data: \(data)")
    case .parsing(let decodingError):
        print("Error: Failed to decode data. Decoding error: \(decodingError)")
    case .unknown(let underlyingError):
        print("Error: Unknown error occurred. Underlying error: \(underlyingError)")
    }
}
```

For more advanced usage and detailed information on the available functionalities, please refer to the documentation.

## Continuous Integration with GitHub Actions

HTTPLib utilizes GitHub Actions for continuous integration. The provided workflow helps ensure that the library builds successfully, passes tests, and maintains code quality standards. Here's a brief overview of the available workflows:

- **Build and Test**: This workflow is triggered on every push and pull request to the repository. It builds the library, runs the test suite, and generates test coverage reports. You can review the workflow runs and their status in the "Actions" tab of the GitHub repository.

### Running the Pipeline Locally

To run the GitHub Actions pipeline locally, you can utilize the `act` command-line tool. `act` allows you to simulate the GitHub Actions environment on your local machine. Here's how to set it up and run the pipeline:

1. Install `act` by following the [official installation guide](https://github.com/nektos/act#installation).

2. Ensure you have Docker installed and running on your machine, as `act` relies on it to create a consistent execution environment.

3. From the root directory of the project, run the following command to execute the GitHub Actions pipeline:

   ```bash
   act
   ```
   
   > Note: If running on an Apple Silicon Mac, don't forget to specify the platform `act --container-architecture linux/amd64`

   This command simulates the Actions environment locally, executing the defined workflows and steps.

4. `act` will analyze the `.github/workflows` directory and run the appropriate workflow based on the changes you made or the default trigger events defined in the workflow files.

   **Note**: Depending on your project configuration, you may need to provide additional environment variables or secrets to simulate the pipeline accurately. Refer to the specific workflow files and their required context to ensure correct execution.

Running the pipeline locally using `act` allows you to validate your changes and test the workflows without pushing to the repository. It's a convenient way to ensure your changes adhere to the defined CI/CD processes.

## Contributing

Contributions to HTTPLib are welcome! If you have any suggestions, bug reports, or feature requests, please open an issue or submit a pull request. We appreciate your valuable contributions.

## License

HTTPLib is released under the [MIT License](https://opensource.org/licenses/MIT). See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

HTTPLib is inspired by the needs of modern Swift developers and aims to provide a reliable and efficient solution for handling HTTP data fetching. We acknowledge the contributions of the open-source community and thank all the developers who have contributed to similar libraries and frameworks that have influenced HTTPLib's development.

---

We hope that HTTPLib simplifies your data fetching needs and enables you to build powerful applications with ease. If you have any questions or need assistance, please don't hesitate to reach out.

Happy coding!

# dataworks-sft-agent

### Running the image

#### Environment Variables

Both of these variables are required.

|             Key            |          Example value           |                       Description                        |
|----------------------------|----------------------------------|----------------------------------------------------------|
| SFT_AGENT_CONFIG_S3_BUCKET | 0a123b4567cd89efg0hi1j23k4l5mn67 | The ID of the config S3 bucket                           |
| SFT_AGENT_CONFIG_S3_PREFIX | example_folder/sub_folder/       | The directory path of the config files within the bucket |

#### Configuration

The two following config files are required, both will be pulled from S3 at runtime using the details provided in the
above environment variables.

* agent-config.yml
* agent-application-config.yml

#### Metrics
This image is started along with [JMX prometheus exporter](https://github.com/prometheus/jmx_exporter)
By default the JMX exporter is runnig on port 9996 and will be acessible at http://localhost:9996/metrics

The metrics exposed are:
- JVM runtime: information about heap memory usage, thread count, and classes. 

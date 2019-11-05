# Tinkerforge

Bindings and easy-to-use wrapper classes to make Crystal code interact with [TinkerForge](https://www.tinkerforge.com/) components.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     tinkerforge:
       github: mathalaxy/tinkerforge
       branch: master
   ```

2. Run `shards install`

## Usage

```crystal
require "tinkerforge"

staple = TF::Staple.new
staple.connect ip_address: "localhost", port: 4223

if staple.connected?
  staple.devices.each do |dev|
    case dev
    when TF::MasterBrick
      puts "Master of the universe!"
    when TF::RotaryPotiBricklet
      puts "Rotary Poti shows #{dev.position}"
    end
  end
end
```

## Development

Currently, there is only support for a very limited set of TF components, because these are what I use in other projects. Supported bricks/bricklets are:

- [MasterBrick](https://www.tinkerforge.com/doc/Hardware/Bricks/Master_Brick.html)
- [SilentStepperBrick](https://www.tinkerforge.com/doc/Hardware/Bricks/Silent_Stepper_Brick.html)
- [RotaryPotiBricklet](https://www.tinkerforge.com/doc/Hardware/Bricklets/Rotary_Poti.html)

If you would like to add support for other components, please feel free to contribute!

## Contributing

1. Fork it (<https://github.com/mathalaxy/tinkerforge/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [mathalaxy](https://github.com/mathalaxy) - creator and maintainer

[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://mathalaxy.github.io/tinkerforge/)

[![GitHub release](https://img.shields.io/github/release/mathalaxy/tinkerforge.svg)](https://github.com/mathalaxy/tinkerforge/releases)

[![Build Status](https://travis-ci.org/mathalaxy/tinkerforge.svg?branch=master)](https://travis-ci.org/mathalaxy/tinkerforge)

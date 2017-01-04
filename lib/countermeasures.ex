defmodule Countermeasures do
  use Application

  def start(_, _) do
    {:ok, led_1} = Gpio.start_link(18, :output)
    Gpio.write(led_1, 0)

    {:ok, laser} = Gpio.start_link(17, :output)
    Gpio.write(laser, 0)

    {:ok, vibration} = Gpio.start_link(23, :input)
    {:ok, sensors} = I2c.start_link("i2c-1", 0x48)

    spawn(fn -> loop(%{led_1: led_1, sensors: sensors, vibration: vibration}) end)

    IO.puts "Intrusion Countermeasures On!"

    {:ok, self}
  end

  def loop(%{led_1: led_1, sensors: sensors, vibration: vibration} = state) do
    :timer.sleep(200)

    # value = read_sensor(sensors, 0)
    # if value > 50 do
    #   alarm("Laser triggered! (#{value})", state)
    # end

    value = read_sensor(sensors, 1)
    if value < 236 do
      alarm("Temperature triggered! (#{value})", state)
    end

    # value = Gpio.read(vibration)
    # if value == 0 do
    #   alarm("Vibration triggered! (#{value})", state)
    # end

    # value = read_sensor(sensors, 2)
    # if value < 110 do
    #   alarm("Noise triggered! (#{value})", state)
    # end

    Gpio.write(led_1, 0)
    loop(state)
  end

  defp alarm(msg, %{led_1: led_1} = state) do
    IO.puts msg
    Gpio.write(led_1, 1)
    loop(state)
  end

  defp read_sensor(pid, channel) do
    {channel_value, _} = Integer.parse("#{channel + 40}", 16)
    I2c.write(pid, <<channel_value>>)
    I2c.read(pid, 1)
    <<value>> = I2c.read(pid, 1)
    value
  end
end

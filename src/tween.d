import bettercmath.misc;
import bettercmath.valuerange;
import easings = bettercmath.easings;

struct Tween(string easingName = "linear")
{
    float duration = 1;
    float time = 0;
    float speed = 1;
    private float _value;
    bool running = true;
    bool looping = false;
    bool yoyo = false;

    invariant
    {
        assert(duration > 0);
    }

    float valueFromTime() const
    {
        alias easingFunc = __traits(getMember, easings, easingName);
        return easingFunc!float(time / duration);
    }

    float value() const
    {
        return _value;
    }
    T value(T)(const T from, const T to)
    {
        return lerp(from, to, value);
    }
    T value(T)(const ValueRange!T range) const
    {
        return range.lerp(_value);
    }

    void initialize()
    {
        _value = valueFromTime();
    }

    void update(double dt)
    {
        if (running)
        {
            time += dt * speed;
            if (time > duration || time < 0)
            {
                if (yoyo)
                {
                    speed = -speed;
                }
                else if (looping)
                {
                    time %= duration;
                }
                running = looping;

                import std.algorithm : clamp;
                time = clamp(time, 0, duration);
            }
            _value = valueFromTime();
        }
    }
}

import bettercmath.easings;
import bettercmath.misc;
import bettercmath.valuerange;

enum TweenOptions
{
    none = 0,
    yoyo = 1 << 0,
    endCallback = 1 << 1,
}

struct Tween(alias easingName = "linear", int options = TweenOptions.none)
{
    enum easingFunc = Easing!float.named!easingName;

    float duration = 1;
    float time = 0;
    float speed = 1;
    private float _value;
    bool running = true;
    bool looping = false;

    static if (options & TweenOptions.yoyo)
    {
        bool yoyoLoops = true;
    }
    static if (options & TweenOptions.endCallback)
    {
        void delegate () endCallback;
    }

    invariant
    {
        assert(duration > 0);
    }

    void reset()
    {
        time = 0;
    }

    bool isRewinding() const
    {
        return speed < 0;
    }

    @property float position() const
    {
        return time / duration;
    }
    @property void position(const float value)
    {
        time = value * duration;
    }

    float valueFromTime() const
    {
        return easingFunc(position);
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
                static if (options & TweenOptions.yoyo)
                {
                    speed = -speed;
                    running = looping || (yoyoLoops && isRewinding);
                }
                else
                {
                    if (looping)
                    {
                        time %= duration;
                    }
                    else
                    {
                        running = false;
                    }
                }

                import std.algorithm : clamp;
                time = clamp(time, 0, duration);
                static if (options & TweenOptions.endCallback)
                {
                    if (endCallback) endCallback();
                }
            }
            _value = valueFromTime();
        }
    }
}

public import bettercmath.easings;

struct Tween(alias easing = linear!float)
{
    float duration = 1;
    float time = 0;
    float speed = 1;
    float value;
    bool running = true;
    bool looping = false;
    bool yoyo = false;

    invariant
    {
        assert(duration > 0);
    }

    float valueFromTime()
    {
        return easing(time / duration);
    }

    void initialize()
    {
        value = valueFromTime();
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
            value = valueFromTime();

    //if time > self.duration or time < 0 then
        //if self.yoyo then
            //self.speed = -self.speed
        //elseif self.looping then
            //time = time % self.duration
        //end

        //self.running = self.looping
        //time = clamp(time, 0, self.duration)
    //end

        }
    }
}

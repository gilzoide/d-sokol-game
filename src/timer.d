struct Timer
{
    private double _time = 0;

    invariant
    {
        assert(_time >= 0);
    }

    @property time() const
    {
        return _time;
    }

    void reset()
    {
        _time = 0;
    }

    void update(double dt)
    {
        _time += dt;
    }
}

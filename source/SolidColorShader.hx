class SolidColorShader {
    public var shader:CustomShader;

    public var color:Int;

    public var red:Int = 0;
    public var green:Int = 0;
    public var blue:Int = 0;

    public var redPercent:Float = 0;
    public var greenPercent:Float = 0;
    public var bluePercent:Float = 0;

    public function new(color:Int) {
        shader = new CustomShader("solidColor");
        setColor(color);
    }

    public function setColor(color:Int) {
        red = getRedFromColor(color);
        green = getGreenFromColor(color);
        blue = getBlueFromColor(color);

        redPercent = red / 255;
        greenPercent = green / 255;
        bluePercent = blue / 255;

        setShaderColor(redPercent, greenPercent, bluePercent);

        this.color = color;
    }

    private function getRedFromColor(color:Int) {
        return (color >> 16) & 0xFF;
    }

    private function getGreenFromColor(color:Int) {
        return (color >> 8) & 0xFF;
    }

    private function getBlueFromColor(color:Int) {
        return color & 0xFF;
    }

    private function setShaderColor(r:Float, g:Float, b:Float) {
        shader.channel_R = r;
        shader.channel_G = g;
        shader.channel_B = b;
    }

    public function destroy() {
        shader = null;
    }
}
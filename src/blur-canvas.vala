[GtkTemplate(ui = "/com/github/humxc/aikadm/ui/blur-canvas.ui")]
public class Aikadm.BlurCanvas : Gtk.Box {
    [GtkChild]
    private unowned Gtk.Picture picture;
    private Gsk.Renderer renderer = new Gsk.NglRenderer();
    public void draw(Gdk.Texture t, double scale_factor, int blur_radius, double brightness, int offset_x, int offset_y, int offset_w, int offset_h) {
        var blurRadius = (float) (blur_radius * scale_factor);
        var scaledW = (float) (t.get_width() * scale_factor);
        var scaledH = (float) (t.get_height() * scale_factor);
        var scaled = scale(t, scaledW, scaledH);
        var bottom = scale(scaled.get_texture(), scaledW + blurRadius * 2, scaledH + blurRadius * 2);
        var top = new Gsk.TextureNode(scaled.get_texture(), rect(blurRadius, blurRadius, scaledW, scaledH));
        Gsk.RenderNode node;
        node = new Gsk.BlendNode(bottom, top, Gsk.BlendMode.DEFAULT);
        node = new Gsk.BlurNode(node, blurRadius);
        node = darken(node, (float) brightness);
        var blured = renderer.render_texture(node, rect(blurRadius, blurRadius, scaledW, scaledH));
        int x = offset_x;
        int y = offset_y;
        int w = (offset_w <= 0 ? t.get_width() + offset_w : offset_w);
        int h = (offset_h <= 0 ? t.get_height() + offset_h : offset_h);

        node = new Gsk.TextureScaleNode(blured, rect(0, 0, t.get_width(), t.get_height()), Gsk.ScalingFilter.LINEAR);
        var result = renderer.render_texture(node, rect(x, y, w, h));
        picture.set_size_request(w, h);
        picture.set_paintable(result);
    }

    private Gsk.TextureScaleNode scale(Gdk.Texture t, float w, float h) {
        var scaledRect = rect(0, 0, w, h);
        print("SSSScaled %f %f", scaledRect.size.width, scaledRect.size.height);
        return new Gsk.TextureScaleNode(t, scaledRect, Gsk.ScalingFilter.LINEAR);
    }

    private Gsk.ColorMatrixNode darken(Gsk.RenderNode node, float brightness) {
        var color_matrix = Graphene.Matrix().init_identity();
        color_matrix.scale(brightness, brightness, brightness);
        var color_offset = Graphene.Vec4().init(0, 0, 0, 0);
        return new Gsk.ColorMatrixNode(node, color_matrix, color_offset);
    }

    construct {
        renderer.realize(null);
    }
}
private Graphene.Rect rect(float x, float y, float w, float h) {
    return Graphene.Rect.alloc().init(x, y, w, h);
}
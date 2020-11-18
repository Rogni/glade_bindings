module glade.builder_bindings;
import gtk.Builder;
import std.traits;
import std.typecons;
import gobject.Signals;

/**
 * Exception if gobject by id not found
 */
final class BadGobjectIdException
    : Exception
{
    /**
     * Construct exception by gobject id;
     */
    this(string id, string filename, string file = __FILE__, size_t line = __LINE__) {
        super("Id `" ~ id ~ "` in file `" ~ filename ~ "` not found", file, line);
    }
}

/**
 * Exception if signal id not found
 */
final class BadSignalIdException
    : Exception
{
    /**
     * Construct exception by gobject id;
     */
    this(string gobject, string id, string filename, string file = __FILE__, size_t line = __LINE__) {
        super("Signal id `" ~ id ~ "` of gobject `" ~ gobject ~"` in file `" ~ filename ~ "` not found", file, line);
    }
}

/// Path of ui file attribute
struct GUIPath
{
    /// storage types
    enum PathType {
        File, /// in filesystem
        Resource /// in gresourse system
    }
    /// storage type
    PathType type;
    
    /// path to file
    string path;

    /// construct with path
    this (string path, PathType type = PathType.Resource) {
        this.path = path;
        this.type = type;
    }

    this (GUIPath other) {
        this.path = other.path;
        this.type = other.type;
    }
}

/// load builder content with GUIPath attribute
Builder load_from_path(Builder builder, ref GUIPath gpath) {
    if (gpath.type == GUIPath.PathType.Resource) {
        builder.addFromResource(gpath.path);
    } else {
        builder.addFromFile(gpath.path);
    }
    return builder;
}

/**
 * Custom GObject id
 */
struct GObjectId {
    /**
     * new gobject id
     */
    string id;

    /**
     * construct with new gobject id
     */
    this (string _id) {
        id = _id;
    }
}

/**
 *
 */
struct GCallbackId {


    /**
     * new callback id
     */
    string id;

    string gobjectId;

    /**
     * construct with new callback id
     */
    this (string _gobjectId, string _id) {
        id = _id;
        gobjectId = _gobjectId;
    }
}


/**
 * Unpack gtk ui from builder to UIStructother
 * TODO: implement connect signals from builder to UIStruct
 */
void load_ui(UIStruct)(UIStruct ui) 
{
    static if (!hasUDA!(UIStruct, GUIPath)) {
        static assert(false, "UIStruct ui must have path attribute");
    }
    
    Builder builder = new Builder;
    GUIPath filepath = getUDAs!(UIStruct, GUIPath);
    load_from_path(builder, filepath);

    foreach (alias member; getSymbolsByUDA!(UIStruct, GObjectId)) {   
        const auto objidattr = getUDAs!(member, GObjectId);
        if (objidattr.length>0) {
            auto temp = builder.getObject( objidattr[0].id );
            if (temp is null) throw new BadGobjectIdException (objidattr[0].id, filepath.path);
            mixin("ui." ~ member.stringof ~ " = cast(typeof (member)) temp;");
        }
    }

    foreach (alias member; getSymbolsByUDA!(UIStruct, GCallbackId)) {   
        const auto objidattr = getUDAs!(member, GCallbackId);
        if (objidattr.length>0) {
            auto temp = builder.getObject( objidattr[0].gobjectId );
            if (temp is null) throw new BadGobjectIdException (objidattr[0].gobjectId, filepath.path);
            if (Signals.connect(temp, objidattr[0].id, () {
                    mixin("ui." ~ __traits(identifier, member) ~ "();");
                }) == 0)
                throw new BadSignalIdException (objidattr[0].gobjectId, objidattr[0].id, filepath.path);
        }
    }
    
    static if (__traits(compiles, ui.did_load)) {
        ui.did_load();
    }
}


UIStruct load_ui(UIStruct)() {
    UIStruct ui = new UIStruct();
    ui.load_ui();
    return ui;
}
#pragma once

using namespace System;
using namespace System::Drawing;

namespace MaltegoClone {
    public ref class GraphElement abstract
    {
    public:
        property int Id;
        property String^ Type;
        property String^ Text;
        property Point Location;
        property System::Drawing::Size Size;
        property Color Color;
        
        virtual void Draw(Graphics^ g) abstract;
        
        property Rectangle Bounds {
            Rectangle get() { return Rectangle(Location, Size); }
        }
    };
}
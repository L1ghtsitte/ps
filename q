#pragma once

#include <map>
#include <string>

using namespace System;
using namespace System::Drawing;
using namespace System::Collections::Generic;

namespace MaltegoClone {

    public ref class GraphElement
    {
    public:
        int Id;
        String^ Type;
        String^ Text;
        Point Location;
        Size Size;
        Color Color;
        Dictionary<String^, String^>^ Properties;

        GraphElement()
        {
            Properties = gcnew Dictionary<String^, String^>();
        }

        property Rectangle Bounds {
            Rectangle get() { return Rectangle(Location, Size); }
        }

        virtual void Draw(Graphics^ g) = 0;
    };
}
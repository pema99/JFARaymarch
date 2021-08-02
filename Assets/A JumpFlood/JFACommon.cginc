// Size of 2D textures representing volume, and actual volume
static const uint texSize = 4096;
static const uint volSize = 256;

// Functions to convert between coordinate spaces
uint Idx3to1(uint3 p, uint size) {
    return p.x + size*p.y + size*size*p.z;
}

uint3 Idx1to3(uint idx, uint size) {
    uint x = idx % size;
    uint y = (idx / size) % size;
    uint z = idx / (size * size);
    return uint3(x, y, z);
}

uint Idx2to1(uint2 p, uint size)
{
    return p.x + size * p.y;
}

uint2 Idx1to2(uint idx, uint size)
{
    uint x = idx % size;
    uint y = idx / size;
    return uint2(x, y);
}

uint2 VolToTex(uint3 volCoord)
{
    uint volIdx = Idx3to1(volCoord, volSize);
    uint2 texCoord = Idx1to2(volIdx, texSize);
    return texCoord;
}

uint3 TexToVol(uint2 texCoord)
{
    uint texIdx = Idx2to1(texCoord, texSize);
    uint3 volCoord = Idx1to3(texIdx, volSize);
    return volCoord;
}
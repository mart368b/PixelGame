#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 2, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) buffer MyDataBuffer {
	float data[];
}
map_data;

layout(set = 0, binding = 1, std430) restrict buffer StaticData {
	int size;
}
static_data;

void move(int from, int to);

// The code we want to execute in each invocation
void main() {

    // Get the index of the current invocation
    uint index = gl_GlobalInvocationID.x;

    // The last index in the matrix (1D array) should be the first index
    // in the next row (2D array)
    uint currentIndex = static_data.size * static_data.size - index - 1;

    int tileType = int(map_data.data[currentIndex]);

    // If the tile is empty, skip it
    if (tileType == 0) {
        return;
    }

    // if the tile is sand (2) try to move it down, if not possible try to move it down-left or down-right
    if (tileType == 2) {
        // If the tile below is empty, move down
        if (currentIndex + static_data.size < static_data.size * static_data.size &&
            map_data.data[currentIndex + static_data.size] == 0) {
            move(int(currentIndex), int(currentIndex + static_data.size));
            return;
        }
        // If the tile down-left is empty, move down-left
        if (currentIndex + static_data.size - 1 >= 0 &&
            currentIndex + static_data.size - 1 < static_data.size * static_data.size &&
            currentIndex % static_data.size != 0 && // Not on the left edge
            map_data.data[currentIndex + static_data.size - 1] == 0) {
            move(int(currentIndex), int(currentIndex + static_data.size - 1));
            return;
        }
        // If the tile down-right is empty, move down-right
        if (currentIndex + static_data.size + 1 < static_data.size * static_data.size &&
            (currentIndex + 1) % static_data.size != 0 && // Not on the right edge
            map_data.data[currentIndex + static_data.size + 1] == 0) {
            move(int(currentIndex), int(currentIndex + static_data.size + 1));
            return;
        }
    }

}

void move(int from, int to) {
    map_data.data[to] = map_data.data[from];
    map_data.data[from] = 0;
}

#include <iostream>
using namespace std;

// Function to sort the array using Bubble Sort
void bubbleSort(int arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                // swap elements
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

// Recursive Binary Search Function
int binarySearch(int arr[], int left, int right, int target) {
    if (left > right)
        return -1; // Base case: not found

    int mid = left + (right - left) / 2;

    if (arr[mid] == target)
        return mid;
    else if (arr[mid] < target)
        return binarySearch(arr, mid + 1, right, target);
    else
        return binarySearch(arr, left, mid - 1, target);
}

int main() {
    int n, target;

    cout << "Enter number of elements: ";
    cin >> n;

    int arr[n];
    cout << "Enter elements (unsorted): ";
    for (int i = 0; i < n; i++)
        cin >> arr[i];

    // Sort the array before searching
    bubbleSort(arr, n);

    cout << "\nArray after sorting: ";
    for (int i = 0; i < n; i++)
        cout << arr[i] << " ";
    cout << endl;

    cout << "\nEnter element to search: ";
    cin >> target;

    // Perform Recursive Binary Search
    int result = binarySearch(arr, 0, n - 1, target);

    if (result != -1)
        cout << "Element found at position " << result + 1 << endl;
    else
        cout << "Element not found." << endl;

    return 0;
}

import { Stack } from "expo-router";
import { View } from "react-native";

export default function PedidosLayout() {
    return (
        <Stack>
            <Stack.Screen
                name="index"
                options={{
                    title: "Pedidos Disponíveis",
                    headerTitleAlign: "center",
                    headerBackground: () => (
                        <View style={{ flex: 1, backgroundColor: "#f6f7f8" }} />
                    ),
                }}
            />
        </Stack>
    );
}

import { MaterialIcons } from "@expo/vector-icons";
import { Tabs } from "expo-router";
import { View } from "react-native";

export default function Layout() {
  return <Tabs>
    <Tabs.Screen
            name="configuracoes"
            options={{
                title: 'Configurações',
                tabBarLabel: 'Configurações',
                headerTitleAlign: 'center',
                headerBackground: () => (<View style={{ flex: 1, backgroundColor: '#f6f7f8' }} />),
                tabBarIcon: ({ color, size }) => (
                    <MaterialIcons name="settings" size={size} color={color} />
                ),
            }}
        />
  </Tabs>;
}

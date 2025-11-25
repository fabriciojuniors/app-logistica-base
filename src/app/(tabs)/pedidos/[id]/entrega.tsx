import { useLocalSearchParams } from "expo-router";
import { Text, View } from "react-native";

export default function Entrega() {
    const { id } = useLocalSearchParams()
    
    return (
        <View>
            <Text>Entrega - {id}</Text>
        </View>
    )
}
import { PedidoListItem } from "@/src/@types/PedidoListItem.type";
import Pedido from "@/src/components/Pedido";
import { useIsFocused } from "@react-navigation/native";
import { useInfiniteQuery } from "@tanstack/react-query";
import React, { useCallback, useMemo } from "react";
import {
    ActivityIndicator,
    FlatList,
    RefreshControl,
    StyleSheet,
    Text,
    View
} from "react-native";

export default function Pedidos() {
    const isFocused = useIsFocused();
    const PAGE_SIZE = 5;

    const fetchPage = async ({ pageParam = 0 }: { pageParam?: number }) => {
        return [] as PedidoListItem[]
    }

    const {
        data,
        isFetching,
        isLoading,
        hasNextPage,
        fetchNextPage,
        refetch,
        isRefetching,
    } = useInfiniteQuery({
        queryKey: ["pedidos"],
        queryFn: fetchPage,
        initialPageParam: 0,
        getNextPageParam: (lastPage, allPages) => {
            if (!lastPage || lastPage.length < PAGE_SIZE) return undefined;
            const totalLoaded = allPages.reduce((acc, page) => acc + page.length, 0);
            return totalLoaded;
        },
        enabled: isFocused,
        gcTime: 0,
        staleTime: 1000 * 5,
    });

    const pedidos = useMemo(() => (data?.pages ?? []).flat(), [data]);

    const onEndReached = useCallback(() => {
        if (hasNextPage && !isFetching) {
            fetchNextPage();
        }
    }, [fetchNextPage, hasNextPage, isFetching]);

    return (
        <View style={styles.container}>

            {isLoading ? (
                <View style={styles.center}>
                    <ActivityIndicator />
                </View>
            ) : (
                <FlatList
                    contentContainerStyle={styles.listContent}
                    data={pedidos}
                    keyExtractor={(item) => item.id}
                    renderItem={({ item }) => <Pedido item={item} />}
                    onEndReachedThreshold={0.5}
                    onEndReached={onEndReached}
                    ListEmptyComponent={
                        <View style={styles.emptyBox}>
                            <Text style={styles.emptyText}>Nenhum pedido encontrado</Text>
                        </View>
                    }
                    refreshControl={
                        <RefreshControl refreshing={isRefetching} onRefresh={refetch} />
                    }
                    ListFooterComponent={
                        isFetching && hasNextPage ? (
                            <View style={styles.footerLoading}>
                                <ActivityIndicator size="small" />
                            </View>
                        ) : null
                    }
                />
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: "#f6f7f8" },
    header: { paddingHorizontal: 16, paddingTop: 12, paddingBottom: 8 },
    headerTitle: { fontSize: 18, fontWeight: "600", color: "#111" },

    searchBox: {
        paddingHorizontal: 16,
        marginBottom: 8,
    },
    searchInput: {
        height: 44,
        borderRadius: 8,
        backgroundColor: "#fff",
        borderWidth: 1,
        borderColor: "#e5e7eb",
        paddingHorizontal: 12,
        color: "#111827",
    },

    listContent: { padding: 16, paddingBottom: 24 },

    card: {
        backgroundColor: "#fff",
        borderRadius: 12,
        padding: 14,
        borderWidth: 1,
        borderColor: "#e5e7eb",
        marginBottom: 12,
        shadowColor: "#000",
        shadowOpacity: 0.05,
        shadowOffset: { width: 0, height: 2 },
        shadowRadius: 6,
        elevation: 1,
    },
    cardHeader: {
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
        marginBottom: 6,
    },
    cardTitle: { fontSize: 16, fontWeight: "700", color: "#111" },
    cardItems: { fontSize: 12, color: "#6b7280" },
    address: { fontSize: 13, color: "#374151" },
    metaLine: { marginTop: 4, fontSize: 12, color: "#6b7280" },

    primaryButton: {
        marginTop: 10,
        backgroundColor: "#2D6CDF",
        height: 40,
        borderRadius: 8,
        alignItems: "center",
        justifyContent: "center",
    },
    primaryButtonText: { color: "#fff", fontWeight: "600" },

    center: { flex: 1, alignItems: "center", justifyContent: "center" },
    emptyBox: { alignItems: "center", padding: 24 },
    emptyText: { color: "#6b7280" },
    footerLoading: { paddingVertical: 12 },
});
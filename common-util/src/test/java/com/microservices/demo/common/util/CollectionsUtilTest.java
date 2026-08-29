package com.microservices.demo.common.util;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class CollectionsUtilTest {

    @Test
    void getInstance_calledTwice_returnsTheSameSingletonInstance() {
        assertThat(CollectionsUtil.getInstance()).isSameAs(CollectionsUtil.getInstance());
    }

    @Test
    void getListFromIterable_withAList_returnsAnEqualListPreservingOrder() {
        List<String> source = List.of("a", "b", "c");

        List<String> result = CollectionsUtil.getInstance().getListFromIterable(source);

        assertThat(result).containsExactly("a", "b", "c");
    }

    @Test
    void getListFromIterable_withANonListIterable_convertsItToAList() {
        LinkedHashSet<Integer> source = new LinkedHashSet<>(List.of(3, 1, 2));

        List<Integer> result = CollectionsUtil.getInstance().getListFromIterable(source);

        assertThat(result).isInstanceOf(List.class).containsExactly(3, 1, 2);
    }

    @Test
    void getListFromIterable_withAnEmptyIterable_returnsAnEmptyList() {
        List<Object> result = CollectionsUtil.getInstance().getListFromIterable(new ArrayList<>());

        assertThat(result).isEmpty();
    }

    @Test
    void getListFromIterable_returnsAFreshMutableListEachCall_notTheSameSourceReference() {
        List<String> source = List.of("only");

        List<String> result = CollectionsUtil.getInstance().getListFromIterable(source);
        result.add("mutated"); // must not throw - List.of() is immutable, so this proves it's a real copy

        assertThat(result).containsExactly("only", "mutated");
    }
}
